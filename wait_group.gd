class_name WaitGroup

## A wrapper class for a callable that emits a signal on execution finished.
class WGCallable:
    signal done

    var callable: Callable
    var args: Array[Variant] = []

    @warning_ignore("shadowed_variable")
    func _init(callable: Callable, args: Array = []):
        self.callable = callable
        self.args = args

    func start() -> void:
        await callable.callv(args)
        done.emit()


var _signal_queue: Array[Signal]
var _callable_queue: Array[WGCallable]
var remaining: int = 0

## Emitted by a [WaitGroup] when all singals that were added to the
## queue have been emitted.
signal all_done

## Emitted by a [WaitGroup] when one of the signals has been emitted.
## Sends the number of signals remaining.
signal one_done(remaining: int)

## Adds signal to wait queue to be waited for.
## The wait group will wait for this signal to be emitted.
func add_signal(s: Signal) -> void:
    if remaining > 0:
        push_error("unable to add signal signal to queue while signals are being played")
    _signal_queue.append(s)

## Adds a callable to the wait queue.
## The function gets called when WaitGroup.wait() is called.
## The wait group will wait for this function to finish execution.
func add_callable(callable: Callable, args: Array[Variant] = []) -> void:
    if remaining > 0:
        push_error("unable to add callable to queue while signals are being played")
    _callable_queue.append(WGCallable.new(callable, args))

## Connects all signals and callables to [WaitGroup].
## This function will finished execution once all signals are emitted
## as well as all callables are done executing.
func wait() -> void:

    # If there are no connected signals then finished early.
    if _connect_signals() == 0:
        all_done.emit()
        return

    for c in _callable_queue:
        c.start()

    # Check if remaining is 0 in the case that all signals and callables
    # were already finished.
    if remaining == 0:
        all_done.emit()
        return

    await all_done

func _connect_signals() -> int:
    remaining = _signal_queue.size() + _callable_queue.size()
    for s in _signal_queue: s.connect(_on_one_finished)
    for c in _callable_queue: c.done.connect(_on_one_finished)
    return remaining

func _disconnect_signals() -> void:
    for s in _signal_queue: s.disconnect(_on_one_finished)
    for c in _callable_queue: c.done.disconnect(_on_one_finished)

func _on_one_finished() -> void:
    remaining -= 1
    one_done.emit(remaining)
    if remaining == 0:
        _on_all_done()

func _on_all_done() -> void:
    _disconnect_signals()
    _signal_queue.clear()
    _callable_queue.clear()
    all_done.emit()
