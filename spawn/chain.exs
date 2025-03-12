defmodule Chain do
  def counter(next_pid) do
    receive do
      n ->
        send next_pid, n + 1
    end
  end

  def create_processes(n) do
    code_to_run = fn(_, send_to) ->
      spawn(Chain, :counter, [send_to])
    end

    # This code calculates the last process in our circle
    # of processes. As a side-effect, it creates `n` processes.
    # Each call to `code_to_run()` will return the PID of
    # the newly created process as the "value" of the
    # accumulator function. When all `n` processes are created,
    # the final value of the accumulator is the PID of the
    # last process in our cycle. Additionally, each spawned
    # process "knows" the value of the previous process in the
    # cycle so that, because of `counter`, can send a message
    # of `n + 1` to the previous process.
    last = Enum.reduce(1..n, self(), code_to_run)

    # We start the count by sending zero ('0') to the last process
    send(last, 0)

    # This process now waits for the final result to be sent to it.
    receive do
      final_answer when is_integer(final_answer) ->
        "Result is #{inspect(final_answer)}"
      other_answer ->
        "Other answer is #{inspect(other_answer)}"
    end
  end

  def run(n) do
    :timer.tc(Chain, :create_processes, [n])
    |> IO.inspect
  end
end
