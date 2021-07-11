defmodule SSHProjectWeb.PageController do
  use SSHProjectWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
