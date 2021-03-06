defmodule PlugSessionRedis do
	use Application

	def start(_type, _args) do
    import Supervisor.Spec, warn: false
 		# See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PlugSessionRedis.Supervisor]
    Supervisor.start_link([pool_spec()], opts)
  end

  def pool_spec() do
    worker_args = {:redo, conf[:redis]}
    child_spec(conf[:name], conf[:pool], worker_args)
  end

  defp conf do
    Application.get_env(:plug_session_redis, :config)
  end

  defp child_spec(pool_name, pool_args, redis_args) do
    strategy = Keyword.get(pool_args, :strategy, :fifo)
    pool_args = [strategy: strategy, name: {:local, pool_name}, worker_module: PlugSessionRedis.Worker] ++ pool_args

    :poolboy.child_spec(pool_name, pool_args, redis_args)
  end

end
