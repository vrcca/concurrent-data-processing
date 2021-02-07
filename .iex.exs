emails = [
  "hello@world.com",
  "hola@world.com",
  "nihao@world.com",
  "konnichiwa@world.com",
]

good_job = fn ->
  Process.sleep(5_000)
  {:ok, []}
end

bad_job = fn ->
  Process.sleep(5_000)
  :error
end

doomed_job = fn ->
  Process.sleep(5_000)
  raise "Boom!"
end
