defmodule KVServer.Command do

  @doc """
  Runs the given `command`.
  """
  def run(command)

  def run({:create, bucket}) do
    KV.Registry.create(KV.Registry, bucket)
    {:ok, "OK\r\n"}
  end

  def run({:get, bucket, key}) do
    lookup bucket, fn pid ->
      value = KV.Bucket.get(pid, key)
      {:ok, "#{value}\r\nOK\r\n"}
    end
  end

  def run({:put, bucket, key, value}) do
    lookup bucket, fn pid ->
      KV.Bucket.put(pid, key, value)
      {:ok, "OK\r\n"}
    end
  end

  def run({:delete, bucket, key}) do
    lookup bucket, fn pid ->
      KV.Bucket.delete(pid, key)
      {:ok, "OK\r\n"}
    end
  end

  @doc ~S"""
  Parses the given `line` into a command.

  ## Examples
  
      iex> KVServer.Command.parse "CREATE shopping\r\n"
      {:ok, {:create, "shopping"}}

      iex> KVServer.Command.parse "CREATE  shopping  \r\n"
      {:ok, {:create, "shopping"}}

      iex> KVServer.Command.parse "PUT shopping milk 1\r\n"
      {:ok, {:put, "shopping", "milk", "1"}}

      iex> KVServer.Command.parse "GET shopping milk\r\n"
      {:ok, {:get, "shopping", "milk"}}

      iex> KVServer.Command.parse "DELETE shopping eggs\r\n"
      {:ok, {:delete, "shopping", "eggs"}}

  Unknown commands or commands with the wrong number of
  arguments return an error:

      iex> KVServer.Command.parse "UNKNOWN shopping eggs\r\n"
      {:error, :unknown_command}

      iex> KVServer.Command.parse "GET shopping\r\n"
      {:error, :unknown_command}

  """
  def parse(line) when is_binary(line) do
    line |> String.split |> _parse
  end

  defp _parse(["CREATE", bucket]) do
    {:ok, {:create, bucket}}
  end

  defp _parse(["PUT", bucket, key, value]) do
    {:ok, {:put, bucket, key, value}}
  end

  defp _parse(["GET", bucket, key]) do
    {:ok, {:get, bucket, key}}
  end

  defp _parse(["DELETE", bucket, key]) do
    {:ok, {:delete, bucket, key}}
  end

  defp _parse(_) do
    {:error, :unknown_command}
  end

  defp lookup(bucket, callback) do
    case KV.Registry.lookup(KV.Registry, bucket) do
      {:ok, pid} -> callback.(pid)
      :error -> {:error, :not_found}
    end
  end
end
