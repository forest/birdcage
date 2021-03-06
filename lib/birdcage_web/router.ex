defmodule BirdcageWeb.Router do
  use BirdcageWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {BirdcageWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]

    plug OpenApiSpex.Plug.PutApiSpec, module: BirdcageWeb.ApiSpec
  end

  scope "/" do
    pipe_through :browser

    get "/session/authenticate", BirdcageWeb.SessionController, :authenticate
    get "/session/callback", BirdcageWeb.SessionController, :callback
  end

  scope "/" do
    pipe_through [:browser, BirdcageWeb.Plugs.RequireLogin]

    get "/session/logout", BirdcageWeb.SessionController, :logout

    live "/", BirdcageWeb.DashboardLive, :index
  end

  # Other scopes may use custom stacks.
  scope "/api" do
    pipe_through :api

    post("/confirm/rollout", BirdcageWeb.WebhookController, :confirm_rollout)
    post("/confirm/promotion", BirdcageWeb.WebhookController, :confirm_promotion)

    get "/openapi", OpenApiSpex.Plug.RenderSpec, []
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      get "/swaggerui", OpenApiSpex.Plug.SwaggerUI, path: "/api/openapi"

      live_dashboard "/observer", metrics: BirdcageWeb.Telemetry
    end
  end
end
