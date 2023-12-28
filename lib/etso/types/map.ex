defmodule Etso.Ecto.MapType do
  use Ecto.Type

  @impl Ecto.Type
  def type, do: :map

  @impl Ecto.Type
  def cast(map) when is_map(map), do: {:ok, map}

  def cast(_), do: :error

  @impl Ecto.Type
  def load(data) when is_map(data), do: {:ok, data}

  @impl Ecto.Type
  def dump(%{} = map), do: {:ok, stringify_atom_keys(map)}
  def dump(_), do: :error

  defp stringify_atom_keys(%{__struct__: module} = value)
       when module not in [Date, DateTime, Decimal, NaiveDateTime, Time] do
    value
    |> Map.from_struct()
    |> stringify_atom_keys()
  end

  defp stringify_atom_keys(value) when is_map(value) and not is_struct(value) do
    value
    |> Enum.map(fn {key, value} -> {to_string(key), stringify_atom_keys(value)} end)
    |> Enum.into(%{})
  end

  defp stringify_atom_keys(value) when is_list(value) do
    Enum.map(value, &stringify_atom_keys/1)
  end

  defp stringify_atom_keys(nil), do: nil
  defp stringify_atom_keys(value) when is_boolean(value), do: value
  defp stringify_atom_keys(value) when is_atom(value), do: to_string(value)
  defp stringify_atom_keys(value), do: value
end

