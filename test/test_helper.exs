ExUnit.start()

Application.put_env(:phoenix, :filter_parameters, [])
Application.put_env(:phoenix, :format_encoders, [json: Poison])

Code.require_file "test/support/repo.ex"
Code.require_file "test/support/conn_case.ex"
Code.require_file "test/support/user_migration.ex"
Code.require_file "test/support/user.ex"
Code.require_file "test/support/mailing.ex"
Code.require_file "test/support/factory.ex"
Code.require_file "test/support/router.ex"
Code.require_file "test/support/endpoint.ex"
# Code.require_file "test/support/app.ex"