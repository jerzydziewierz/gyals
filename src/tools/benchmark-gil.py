# benchmark the GIL with write to a global state.
import time
import threading

thread_count = 8
loop_count = 20000000
instructions_per_loop = 3

# define a function that does some work
global j
j = 0


def do_work():
    global j
    for i in range(loop_count):
        j += i
        j *= i
        j %= (i + 1)

    print(f'j={j}')


# define a function that creates and starts 3 threads
def benchmark():
    threads = []
    for i in range(thread_count):
        t = threading.Thread(target=do_work)
        threads.append(t)
        t.start()

    # wait for all threads to finish
    for t in threads:
        t.join()


# measure the time it takes to run the benchmark function
start_time = time.monotonic()
benchmark()
end_time = time.monotonic()

# calculate the maximum command throughput across all threads
total_commands = thread_count * loop_count * instructions_per_loop
elapsed_time = end_time - start_time
throughput = total_commands / elapsed_time

print(f"Elapsed time: {elapsed_time:.3f} seconds")
print(f"Throughput: {throughput:.3f} commands per second")
