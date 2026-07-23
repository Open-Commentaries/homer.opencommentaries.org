import Config

# Used only by `mix generate_static` (see @preferred_cli_env in
# lib/mix/tasks/generate_static.ex). Mirrors prod's code_reloader/debug_errors
# settings (compile-time, so this must be a real Mix env, not a runtime flag)
# without prod's SSL/secret-key requirements, which don't apply to a one-shot
# static render.
config :ahcip, AHCIPWeb.Endpoint,
  code_reloader: false,
  debug_errors: false,
  check_origin: false,
  server: false,
  secret_key_base: "Cc4dXsUBU0MDdN8kLdDcefaREZEGmeeWIrY5uZ7swaateq8/ByjQmsSAgfGzGl/2"

config :logger, level: :info
