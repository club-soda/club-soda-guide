defmodule CsGuide.Mock.ExAws do
  @moduledoc false
  def request(op) do
    case String.contains?(op.path, "bad-file") do
      true ->
        {:error, :error}

      _ ->
        {:ok, :ok}
    end
  end
end
