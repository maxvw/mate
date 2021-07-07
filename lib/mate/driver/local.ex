defmodule Mate.Driver.Local do
  @moduledoc """
  The Local driver is used to execute commands on your local machine.

  Be aware that if you want to deploy your application on another machine, they
  must match system architectures. For example if you build locally on MacOS you
  cannot deploy the application to Ubuntu.

  Example configuration:

      config :mate,
        otp_app: :example,
        module: Example,
        driver: Mate.Driver.Local

      config :staging,
        server: "www.example.com",
        build_path: "/tmp/mate/example",
        release_path: "/home/elixir/releases/example",
        build_secrets: %{
          "prod.secret.exs" => "\#{File.cwd!()}/config/prod.secret.exs"
        }

  """
  alias Mate.Pipeline
  alias Mate.Helpers
  use Mate.Session
  use Mate.Driver

  @impl true
  def start(session, _host) do
    {:ok, session |> set_conn("localhost")}
  end

  @impl true
  def current_host(_session) do
    "localhost"
  end

  @impl true
  def prepare_source(%{remote: remote} = session) do
    # prepare git remote
    git_remote_name = "mate-#{remote.id}"
    git_remote_url = "file://" <> remote.build_path

    # Ensure the remote to local build directory exists
    # this overrides the same logic in `VerifyGit`, which will skip this step
    # if the remote name is already defined. To push to a local directory it
    # has to use a file:///path/to/build_dir format.
    with {:error, _error} <-
           Helpers.local_cmd(session, "git", ~w{remote get-url #{git_remote_name}}),
         {:error, error} <-
           Helpers.local_cmd(session, "git", ~w{remote add #{git_remote_name} #{git_remote_url}}) do
      Helpers.bail(session, "Failed to ensure remote origin on local git repository.", error)
    end

    {:ok,
     session
     |> Pipeline.run_step(Mate.Step.VerifyGit)
     |> Pipeline.run_step(Mate.Step.SendGitCommit)}
  end

  @impl true
  def exec(session, command, args) do
    Helpers.local_cmd(session, command, args)
  end

  @impl true
  def exec_script(session, script) do
    Helpers.local_script(session, script)
  end

  @impl true
  def copy_from(session, remote_src, local_dest) do
    case File.copy(remote_src, local_dest) do
      {:ok, _} -> {:ok, session}
      error -> error
    end
  end

  @impl true
  def copy_to(session, local_src, remote_dest) do
    case File.copy(local_src, remote_dest) do
      {:ok, _} -> {:ok, session}
      error -> error
    end
  end
end
