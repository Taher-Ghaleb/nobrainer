module NoBrainer::QueryRunner::Driver
  def run(env)
    # TODO have a logger
    # puts env[:query].inspect
    NoBrainer.connection.run(env[:query], env[:options])
  end
end
