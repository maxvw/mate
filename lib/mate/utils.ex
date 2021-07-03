defmodule Mate.Utils do
  @moduledoc """
  This module contains some small helper utilities.
  """
  import Macro, only: [camelize: 1]

  @doc ~S"""
  Returns the otp app from the current Mix Project.

  Example:
      iex> Mate.Utils.otp_app()
      :mate
  """
  @spec otp_app() :: atom()
  def otp_app do
    Mix.Project.config() |> Keyword.fetch!(:app)
  end

  @doc ~S"""
  Returns the namespace Module name from the current Mix Project.

  Example:
      iex> Mate.Utils.module()
      "Mate"
  """
  @spec module() :: String.t()
  def module do
    otp_app = otp_app()

    case Application.get_env(otp_app, :namespace, otp_app) do
      ^otp_app -> otp_app |> to_string() |> camelize()
      mod -> mod |> inspect()
    end
  end

  @doc ~S"""
  Returns the sanitized module name as a string.

  Example:
      iex> Mate.Utils.module_name(Mate)
      "Mate"

      iex> Mate.Utils.module_name(%Mate.Pipeline{})
      "Mate.Pipeline"

      iex> Mate.Utils.module_name("Elixir.Mate")
      "Mate"
  """
  @spec module_name(map() | atom() | String.t()) :: String.t()
  def module_name(%module{}), do: module_name(module)

  def module_name(module) when not is_binary(module) do
    module |> to_string |> module_name
  end

  def module_name("Elixir." <> module), do: module_name(module)
  def module_name(module), do: module

  @doc """
  Returns a random id of any given length

  Examples:
    iex> Mate.Utils.random_id()
    "3T440PTEM1IFD64I9R8MU2L2TIAGSF1TRQDH394HCUS5IRJHCGL0"

    iex> Mate.Utils.random_id(6)
    "HGEE0AFSH0"
  """
  @spec random_id() :: String.t()
  @spec random_id(integer()) :: String.t()
  def random_id(len \\ 32) do
    :crypto.strong_rand_bytes(len)
    |> Base.hex_encode32(padding: false)
    |> String.slice(0, len)
  end

  @doc """
  Returns a boolean to determine if the given value is empty.

  Examples:
    iex> Mate.Utils.empty?("")
    true

    iex> Mate.Utils.empty?([])
    true

    iex> Mate.Utils.empty?(nil)
    true

    iex> Mate.Utils.empty?("Hello")
    false

    iex> Mate.Utils.empty?([1,2,3])
    false
  """
  @spec empty?(nil | String.t() | list()) :: boolean()
  def empty?(string) when is_binary(string), do: String.trim("#{string}") == ""
  def empty?([]), do: true
  def empty?(nil), do: true
  def empty?(_), do: false
end
