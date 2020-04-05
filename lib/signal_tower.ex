defmodule SignalTower do
  use Application
  import Supervisor.Spec, warn: false

  def start(_type, _args) do
    start_cowboy()
    |> start_supervisor()
  end

  def stop(_state) do
    :ok
  end

  defp start_cowboy() do
    {port, _} = Integer.parse(System.get_env("PALAVA_RTC_ADDRESS") || "4233")

    dispatch = :cowboy_router.compile([
      {:_, [{"/[...]", SignalTower.WebsocketHandler, []}]}
    ])

    {port, dispatch}
  end

  def observe_ds() do
    Process.monitor(SignalTower.RoomSupervisor)
    receive do
      {:DOWN, _, _, proc, reason} when reason != :noproc ->
        IO.inspect {"ds", proc, reason}
        observe_ds()
    end
  end

  def observe_stats() do
    Process.monitor(SignalTower.Stats)
    receive do
      {:DOWN, _, _, proc, reason} when reason != :noproc ->
        IO.inspect {"stats", proc, reason}
        observe_stats()
    end
  end

  def observe_self() do
    Process.monitor(self())
    receive do
      {:DOWN, _, _, proc, reason} when reason != :noproc ->
        IO.inspect {"self", proc, reason}
        observe_self()
    end
  end

  defp start_supervisor({port, dispatch}) do
    IO.puts "start supervisors!"
    env_stats_file = System.get_env("PALAVA_STATS_FILE")
    stats_file = if env_stats_file && env_stats_file != "", do: env_stats_file, else: "room-stats.csv"
    children = [
      {DynamicSupervisor, name: SignalTower.RoomSupervisor, strategy: :one_for_one, max_restarts: 5},
      {SignalTower.Stats, [stats_file]},
      %{id: :cowboy, start: {:cowboy, :start_clear, [:http, [port: port], %{env: %{dispatch: dispatch}}]}}
    ]
    spawn(&observe_ds/0)
    spawn(&observe_stats/0)
    spawn(&observe_self/0)
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
