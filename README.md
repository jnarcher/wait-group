# WaitGroup - Asynchronous Task Synchronization in Godot

## Overview
`WaitGroup` is a custom class that helps manage and synchronize multiple asynchronous tasks in Godot. It allows you to queue signals and callables (functions) and wait for their completion before proceeding further. Once all tasks are done, a signal `all_done` is emitted.

This is useful when you need to run multiple tasks concurrently (like handling signals or running functions) and wait for all of them to finish before continuing execution in your game or application.

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

You can create a `WaitGroup` instance to manage the synchronization of multiple tasks. Here is an example of how to use it in your game or application:

```gdscript
# Create a new WaitGroup instance
var wg = WaitGroup.new()

# Add signals to the wait group
wg.add_signal(signal_name)

# Add callables to the wait group
wg.add_callable(my_function, [arg1, arg2])

# Wait for all tasks to complete
wg.wait()

# Connect to the 'all_done' signal to perform actions after all tasks are done
wg.connect("all_done", self, "_on_all_done")

func _on_all_done():
    print("All tasks are complete!")
```

### 2. **Adding Signals**
You can add signals to the wait group using the `add_signal()` method. This method ensures that the wait group will wait for the signal to be emitted before continuing.

```gdscript
wg.add_signal(my_signal)
```

### 3. **Adding Callables**
Callables (functions) can be added using the `add_callable()` method. The `WaitGroup` will execute the callable and wait for it to finish.

```gdscript
wg.add_callable(some_function, [arg1, arg2])
```

### 4. **Waiting for Completion**
To wait for all tasks to finish, call the `wait()` method. This will block the code execution until all signals are emitted and all callables have been executed.

```gdscript
wg.wait()
```

Once all tasks are complete, the `all_done` signal is emitted, and you can connect it to your own function to perform actions once all tasks are finished.

```gdscript
wg.connect("all_done", self, "_on_all_done")

func _on_all_done():
    print("All tasks are complete!")
```

### 5. **Clearing Tasks**
If you need to clear the queues of signals and callables before they're processed (e.g., in case of an error), you can use the `clear()` method:

```gdscript
wg.clear()
```

### 6. **Handling Callables and Cleanup**
Each callable wrapped in `WGCallable` will be executed when `start()` is called. Once the callable finishes execution, the `done` signal is emitted, and the task is cleaned up automatically. The `WaitGroup` will ensure that all tasks are completed before emitting the `all_done` signal.

## Example Use Case

```gdscript
# Create a new WaitGroup instance
var wg = WaitGroup.new()

# Example signal
wg.add_signal(my_signal)

# Example callable
wg.add_callable(my_function, [arg1, arg2])

# Wait for all tasks to complete
wg.wait()

# Handle when all tasks are finished
wg.connect("all_done", self, "_on_all_done")

func _on_all_done():
    print("All signals and callables are complete!")
```

## Methods

### `add_signal(signal: Signal)`
Adds a signal to the wait queue. The wait group will wait for this signal to be emitted before proceeding.

### `add_callable(callable: Callable, args: Array = [])`
Adds a callable (function) to the wait queue. The wait group will wait for this function to finish executing.

### `wait()`
Waits for all queued signals and callables to complete. Once all tasks are finished, the `all_done` signal is emitted.

### `clear()`
Clears the signal and callable queues, ensuring no tasks remain.

### `all_done`
Signal emitted when all tasks (signals and callables) have finished.

## Notes
- The `WaitGroup` class relies on signals and callables to manage synchronization. Ensure that all tasks are properly executed and signals are emitted to avoid hanging or incomplete tasks.
- Callables are executed asynchronously, so use `await` to ensure that tasks are completed properly.
- The `WGCallable` class wraps callables and ensures that they emit a `done` signal once execution is finished. This signal is connected to the `WaitGroup` to track the completion of each callable.
