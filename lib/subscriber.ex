defmodule Subscriber do
  @moduledoc """
  Subscriber module for register the subscribers, like `:prepaid`
  or `:pospaid`.
  The most used function is `register/3`
  """
  defstruct [:name, :number, :plan, calls: []]
  @subscribers %{:prepaid => "pre.txt", :pospaid => "pos.txt"}


  @doc """
  Function for register a subscriber as `:prepaid` or `:pospaid`

  ## Parameters
  - name: name of the subscriber
  - number: number of the subscriber
  - plan: optional parameter. If not given, assumes `:prepaid`

  ## Examples

      iex> Subscriber.register("MrDuck", "85999502100", :prepaid)
      {:ok, "Subscriber registered!"}
  """
  def register(name, number, :prepaid), do: register(name, number, %Prepaid{})
  def register(name, number, :pospaid), do: register(name, number, %Pospaid{})
  def register(name, number, plan) do
    case subscribers_by_number(number) do
      nil ->
        subscriber = %__MODULE__{name: name, number: number, plan: plan}
        take_plan(subscriber)
        |> insert_subscriber(subscriber)
        {:ok, "Subscriber registered!"}
      _subscriber ->
        {:error, "This subscriber already exists!"}
    end
  end

  defp take_plan(subscriber) do
    case subscriber.plan.__struct__ == Prepaid do
      true  -> :prepaid
      false -> :pospaid
    end
  end

  @doc """
  Private function for query a subscriber by number and/or plan `:prepaid`
  or `:pospaid`

  ## Parameters
  - number: number of the subscriber
  - key: optional parameter. If not given, assumes `:all`

  ## Examples
      iex> Subscriber.query_subscriber("000", :prepaid)

  """
  def query_subscriber(number, key \\ :all), do: query(number, key)
  defp query(number, :prepaid), do: filter(prepaid_subscribers(), number)
  defp query(number, :pospaid), do: filter(pospaid_subscribers(), number)
  defp query(number, :all),     do: filter(subscribers(), number)
  defp filter(list, number), do: Enum.find(list, &(&1.number == number))

  def subscribers(), do: read(:prepaid) ++ read(:pospaid)
  def prepaid_subscribers(), do: read(:prepaid)
  def pospaid_subscribers(), do: read(:pospaid)

  def subscribers_by_number(number) do
    subscribers()
    |> Enum.find(&(&1.number == number))
  end

  defp insert_subscriber(plan, subscriber) do
    binary =
      [subscriber] ++ read(plan)
      |> :erlang.term_to_binary()
    write(@subscribers[plan], binary)
  end

  def delete_subscriber(number) do
    subscriber_for_delete = query_subscriber(number)

    new_list =
      subscriber_for_delete
      |> take_plan()
      |> read()
      |> List.delete(subscriber_for_delete)
    {subscriber_for_delete, new_list}
  end

  def update_subscriber(subscriber) do
    {deleted_subscriber, new_list} = delete_subscriber(subscriber.number)

    case subscriber.plan.__struct__ == deleted_subscriber.plan.__struct__ do
      true ->
        plan = take_plan(subscriber)

        binary =
          new_list ++ [subscriber]
          |> :erlang.term_to_binary()
        write(@subscribers[plan], binary)

      false -> {:error, "Subscriber cant't change the plan"}
    end
  end

  def read(plan) do
    case File.read(@subscribers[plan]) do
      {:error, :enoent} ->
        binary = :erlang.term_to_binary([])
        write(@subscribers[plan], binary)
        []

      {:ok, binary} -> File.read(@subscribers[plan])
      binary
      |> :erlang.binary_to_term()
    end
  end

  defp write(subscriber_list, plan) do
    File.write!(subscriber_list, plan)
  end
end
