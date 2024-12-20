class_name WaitGroup

## A wrapper class for a callable that emits a signal on execution finished.
class WGCallable:
    signal done

    var callable: Callable
    var args: Array[Variant] = []
    var weak_ref: WeakRef = null

    @warning_ignore("shadowed_variable")
    func _init(callable: Callable, args: Array = []):
        self.callable = callable
        self.args = args

        # Create a weak reference to the current instance
        weak_ref = WeakRef.new()

    func start() -> void:
        await callable.callv(args)
        done.emit()
        _cleanup()

    func _cleanup() -> void:
        # Ensure this callable object is freed after execution (if no other references exists)
        if weak_ref.get_ref() == null:
            return # This object is already freed.
        free()


var _signal_queue: Array[Signal] = []
var _callable_queue: Array[WGCallable] = []
var remaining: int = 0

## Emitted by a [WaitGroup] when all signals that were added to the
## queue have been emitted.
signal all_done

## Adds signal to wait queue to be waited for.
## The wait group will wait for this signal to be emitted.
func add_signal(sig: Signal) -> void:
    assert(remaining == 0, "unable to add signal to queue while signals are being played")
    _signal_queue.append(sig)

## Adds a callable to the wait queue.
## The function gets called when WaitGroup.wait() is called.
## The wait group will wait for this function to finish execution.
func add_callable(callable: Callable, args: Array[Variant] = []) -> void:
    assert(remaining == 0, "unable to add callable to queue while signals are being played")
    assert(callable.is_valid(), "unable to add invalid callable")
    _callable_queue.append(WGCallable.new(callable, args))

## Connects all signals and callables to [WaitGroup].
## This function will finished execution once all signals are emitted
## as well as all callables are done executing.
func wait() -> void:

    # If there are no connected signals then finish early.
    if _connect_signals() == 0:
        _on_all_done()
        return

    for c in _callable_queue:
        c.start()

    # Check if remaining is 0 in the case that all signals and callables
    # were already finished.
    if remaining == 0:
        _on_all_done()
        return

    await all_done

func clear() -> void:
    assert(remaining == 0, "unable to clear WaitGroup while there are remaining tasks.")
    _signal_queue.clear()
    _callable_queue.clear()

func _connect_signals() -> int:
    remaining = _signal_queue.size() + _callable_queue.size()

    for s in _signal_queue:
        s.connect(_on_one_done, Object.CONNECT_ONE_SHOT)

    for c in _callable_queue:
        c.done.connect(_on_one_done, Object.CONNECT_ONE_SHOT)

    return remaining

func _on_one_done() -> void:
    remaining -= 1
    if remaining == 0:
        _on_all_done()

func _on_all_done() -> void:
    clear()
    all_done.emit()

