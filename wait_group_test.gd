extends Node

class TestItem:
    extends Node

    signal done

    func start() -> void:
        await Util.wait(0.1 + randf())
        done.emit()

    func callable_test(id: int) -> void:
        await Util.wait(5 * randf())
        print("await complete on callable id: ", id)

@export var test_count: int = 100

func _ready():
    run_tests()

func run_tests() -> void:
    print("\n============== SIGNALS TEST ==============")
    await test_signals(test_count)
    print("\n============== CALLABLES TEST ============")
    await test_callables(test_count)
    print("\n======== SIGNALS AND CALLABLES TEST ======")
    await test_signals_and_callables(test_count)

    get_tree().quit()

func test_signals(count: int) -> void:
    var start_time = Global.time

    var items: Array[TestItem] = []

    print("creating %d test items..." % count)
    for i in count:
        var item := TestItem.new()
        add_child(item)
        items.append(item)

    print("adding test item signals to wait group...")
    var wg := WaitGroup.new()
    for i in items.size():
        var item := items[i]
        item.done.connect(print.bind("Signal Complete: %d" % i))
        wg.add_signal(item.done)

    print("starting test items")
    for item in items:
        item.start()

    await wg.wait()

    print("SIGNALS TEST COMPLETE (%f seconds)" % [Global.time - start_time])

    for c in get_children(): c.queue_free()

func test_callables(count: int) -> void:
    var start_time = Global.time

    var items: Array[TestItem] = []

    print("creating %d test items..." % count)
    for i in count:
        var item := TestItem.new()
        add_child(item)
        items.append(item)

    print("adding test item callables to wait group...")
    var wg := WaitGroup.new()
    for i in items.size():
        var item := items[i]
        wg.add_callable(item.callable_test, [i])

    await wg.wait()

    print("CALLABLES TEST COMPLETE (%f seconds)" % [Global.time - start_time])

    for c in get_children(): c.queue_free()

func test_signals_and_callables(count: int) -> void:
    var start_time = Global.time

    var items: Array[TestItem] = []

    print("creating %d test items..." % count)
    for i in count:
        var item := TestItem.new()
        add_child(item)
        items.append(item)

    print("adding test item signals and callables to wait group...")
    var wg := WaitGroup.new()
    for i in items.size():
        var item := items[i]
        item.done.connect(print.bind("Signal Complete: %d" % i))
        wg.add_signal(item.done)
        wg.add_callable(item.callable_test, [i])

    print("starting test items")
    for item in items:
        item.start()

    await wg.wait()

    print("SIGNALS AND CALLABLES TEST COMPLETE (%f seconds)" % [Global.time - start_time])

    for c in get_children(): c.queue_free()
    pass
