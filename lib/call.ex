defmodule Call do
  defstruct [:date, :duration]

  def register_call(subscriber, date, duration) do
    updated_subscriber = %Subscriber{
      subscriber
      | calls: subscriber.calls ++ [%__MODULE__{date: date, duration: duration}]
    }
    Subscriber.update_subscriber(updated_subscriber)
  end
end
