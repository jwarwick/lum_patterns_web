defmodule LumPatternsWeb.PageController do
  use LumPatternsWeb.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def create(conn, params = %{"form" => %{"csv" => %Plug.Upload{filename: filename, path: path}}}) do
    tmp_dir = System.tmp_dir!
    tmp_file = Path.rootname(filename) <> ".map"
    tmp_path = Path.join(tmp_dir, tmp_file)
    LumPatterns.Converter.convert_file(path, tmp_path)

    conn
    |> put_resp_header("content-disposition", "attachment; filename=\"#{tmp_file}\"")
    |> send_file(200, tmp_path)
  end
end
