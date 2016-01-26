defmodule LumPatternsWeb.PageController do
  use LumPatternsWeb.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
