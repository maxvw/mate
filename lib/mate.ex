defmodule Mate do
  alias Mate.Session

  def local_cmd(%Session{} = session, cmd, args \\ []) when is_list(args) do
    if session.verbosity > 0,
      do:
        Mix.shell().info([
          :yellow,
          :bright,
          "local >",
          :reset,
          " ",
          cmd,
          " ",
          Enum.join(args, " ")
        ])

    case System.cmd(cmd, args, stderr_to_stdout: true) do
      {stdout, _exit_status = 0} ->
        {:ok, String.trim(stdout)}

      {stdout, exit_status} ->
        {:error,
         "Local command exited with non-ok exit status (#{exit_status})\n\nCommand: #{cmd} #{Enum.join(args, " ")}\nOutput:\n#{stdout}"}
    end
    |> print_result("local", session.verbosity)
  end

  def local_script(%Session{} = session, script) do
    if session.verbosity > 0,
      do: Mix.shell().info([:yellow, "local >", :reset, " ", script])

    case System.cmd("/usr/bin/env", ["bash", "-c", script], stderr_to_stdout: true) do
      {stdout, _exit_status = 0} ->
        {:ok, String.trim(stdout)}

      {stdout, exit_status} ->
        {:error,
         "Local script exited with non-ok exit status (#{exit_status})\n\nScript:\n #{script}\n\nOutput:\n#{stdout}"}
    end
    |> print_result("local", session.verbosity)
  end

  def remote_cmd(%Session{driver: driver} = session, cmd, args \\ []) when is_list(args) do
    if session.verbosity > 0,
      do: Mix.shell().info([:yellow, "remote >", :reset, " ", cmd, " ", Enum.join(args, " ")])

    driver.exec(session, cmd, args)
    |> print_result("remote", session.verbosity)
  end

  def remote_script(%Session{driver: driver} = session, script) do
    if session.verbosity > 0,
      do: Mix.shell().info([:yellow, "remote > ", :reset, " ", script])

    driver.exec(session, script, [])
    |> print_result("remote", session.verbosity)
  end

  def copy_from(%Session{driver: driver} = session, src, dest) do
    if session.verbosity > 0,
      do:
        Mix.shell().info([
          :cyan,
          "remote -> local",
          :reset,
          " ",
          "copying",
          :bright,
          src,
          :reset,
          " to ",
          :bright,
          dest
        ])

    driver.copy_from(session, src, dest)
  end

  def copy_to(%Session{driver: driver} = session, src, dest) do
    if session.verbosity > 0,
      do:
        Mix.shell().info([
          :cyan,
          "local -> remote",
          :reset,
          " ",
          "copying",
          :bright,
          src,
          :reset,
          " to ",
          :bright,
          dest
        ])

    driver.copy_to(session, src, dest)
  end

  defp print_result({:ok, stdout} = result, tag, verbosity) when verbosity > 1 do
    Mix.shell().info([:green, :bright, "#{tag} <", :reset, " ", stdout])
    result
  end

  defp print_result(result, _tag, _verbosity) do
    result
  end
end
