# WaitGroup - Asynchronous Task Synchronization in GDScript

## Overview
`WaitGroup` is a custom class that helps manage and synchronize multiple asynchronous tasks in Godot. It allows you to queue signals and callables (functions) and wait for their completion before proceeding further. Once all tasks are done, a signal `all_done` is emitted.

This is useful when you need to run multiple tasks concurrently (like handling signals or running functions) and wait for all of them to finish before continuing execution in your game or application.

## Requirements
This class uses the `Signal` and `await` APIs in Godot 4. This script will not work for earlier versions.

## Features
- Allows you to queue signals and callables.
- Wait for the completion of all queued signals and callables.
- Emits an `all_done` signal when all tasks are completed.
- Cleans up tasks automatically after they finish to avoid memory leaks.

## Components
1. **WaitGroup**: The main class that manages the synchronization of multiple signals and callables.
2. **WGCallable**: A wrapper class for a callable (function) that emits a signal once it has finished executing.

## Usage

### 1. **Setting Up WaitGroup**

You can create a `WaitGroup` instance to manage the synchronization of multiple tasks.

```gdscript
var wg = WaitGroup.new()
```

### 2. **Adding Signals**
You can add signals to the wait group using the `add_signal()` method. This method ensures that the wait group will wait for the signal to be emitted before continuing.

```gdscript
wg.add_signal(my_signal)
```

### 3. **Adding Callables**
Callables (functions) can be added using the `add_callable()` method. The `WaitGroup` will execute the callable with the given `args` and wait for it to finish.

```gdscript
wg.add_callable(some_function, [arg1, arg2])
```

### 4. **Waiting for Completion**
#### 4.1 Non-Blocking

To wait for all tasks to finish, first connect to the `all_done` signal.

```gdscript
wg.all_done.connect(_on_all_done)

func _on_all_done():
    print("All tasks are complete!")
```

Then call the `wait()` method. 

```gdscript
wg.wait()
```

The `wg.wait()` method will connect to all the signals and call the loaded callables with the given arguments.

This means that if they execute synchronously (i.e. they are not coroutines) then they will complete immediately.

Be sure to connect to the `all_done` signal ***BEFORE*** calling `wg.wait()` so that you won't miss the signal being fired.

Once all tasks are complete, the `all_done` signal is emitted.


#### 4.2 Blocking

Alternatively, await the call directly to block code execution.
```gdscript
# Wait for task completion
await wg.wait()

# Continue the rest of your coroutine...
```

### 6. **Handling Callables and Cleanup**
Each callable wrapped in `WGCallable` will be executed when `start()` is called. Once the callable finishes execution, the `done` signal is emitted, and the task is cleaned up automatically. The `WaitGroup` will ensure that all tasks are completed before emitting the `all_done` signal.

## Methods

### `add_signal(signal: Signal)`
Adds a signal to the wait queue. The wait group will wait for this signal to be emitted before proceeding.

### `add_callable(callable: Callable, args: Array = [])`
Adds a callable (function) to the wait queue. The wait group will wait for this function to finish executing. Calls the callable with the `callable.callv(args)` method.

### `wait()`
Waits for all queued signals and callables to complete. Once all tasks are finished, the `all_done` signal is emitted.

### `all_done`
Signal emitted when all tasks (signals and callables) have finished.

## Notes
- The `WaitGroup` class relies on signals and callables to manage synchronization. Ensure that all tasks are properly executed and signals are emitted to avoid hanging or incomplete tasks.
- Callables are executed asynchronously, so use `await` to ensure that tasks are completed properly.
- The `WGCallable` class wraps callables and ensures that they emit a `done` signal once execution is finished. This signal is connected to the `WaitGroup` to track the completion of each callable.

## Tests
Add the `wait_group_test.gd` script to a root node in an empty scene and run the scene from the editor. 

You will be able to change the number of tests in the editor.

The script will log out the behavior in the output console.
