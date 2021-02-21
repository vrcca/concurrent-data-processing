emails = [
  "hello@world.com",
  "hola@world.com",
  "nihao@world.com",
  "konnichiwa@world.com",
]

pages = [
  "google.com",
  "facebook.com",
  "apple.com",
  "netflix.com",
  "amazon.com"
]

good_job = fn ->
  Process.sleep(5_000)
  {:ok, []}
end

import_job = fn ->
  Process.sleep(60_000)
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
