Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "public/pages#home"

  scope module: :public do
    get "/pricing", to: "pages#pricing", as: :pricing
    get "/portfolio", to: "pages#portfolio", as: :portfolio
    get "/about", to: "pages#about", as: :about

    # Blog
    get "/blog",          to: "blog#index", as: :blog
    get "/blog/feed.rss", to: "blog#feed",  as: :blog_feed, defaults: { format: :rss }
    get "/blog/:slug",    to: "blog#show",  as: :blog_post

    get  "/login",  to: "sessions#new",     as: :login
    post "/login",  to: "sessions#create"
    delete "/logout", to: "sessions#destroy", as: :logout

    get  "/signup", to: "registrations#new",    as: :signup
    post "/signup", to: "registrations#create"

    # Email verification
    get  "/verify-email",    to: "email_verifications#show",   as: :verify_email
    post "/resend-verification", to: "email_verifications#resend", as: :resend_verification

    # Password reset
    get   "/forgot-password", to: "password_resets#new",    as: :new_password_reset
    post  "/forgot-password", to: "password_resets#create"
    get   "/reset-password",  to: "password_resets#edit",   as: :edit_password_reset
    patch "/reset-password",  to: "password_resets#update"

    # Email change confirmation
    get "/confirm-email-change", to: "email_changes#show", as: :confirm_email_change

    # Invitations (public-facing acceptance)
    get  "/invitations/:token", to: "invitations#show",   as: :invitation
    post "/invitations/:token/accept", to: "invitations#accept", as: :accept_invitation
  end

  scope module: :authenticated do
    get "/dashboard", to: "dashboard#show", as: :dashboard

    # Team members
    get "/team", to: "team#index", as: :team
    get "/team/invitations/new", to: "invitations#new", as: :new_team_invitation
    post "/team/invitations", to: "invitations#create", as: :team_invitations
    delete "/team/members/:id", to: "team_members#destroy", as: :team_member

    # Email verification
    post "/email-verification/resend", to: "email_verifications#resend", as: :resend_email_verification

    # Email change
    get   "/settings/email", to: "email_changes#edit",   as: :edit_email_settings
    patch "/settings/email", to: "email_changes#update"

    # Settings sub-namespace
    scope "/settings", module: :settings do
      get   "/account",          to: "accounts#edit",           as: :edit_settings_account
      patch "/account",          to: "accounts#update",         as: :settings_account
      get   "/profile",          to: "profiles#edit",           as: :edit_settings_profile
      patch "/profile",          to: "profiles#update",         as: :settings_profile
      patch "/profile/password", to: "profiles#update_password", as: :settings_profile_password
    end
  end

  namespace :admin do
    resources :users, only: :index do
      member do
        post :verify_email
        post :force_password_reset
        post :impersonate
      end
    end
    delete "/impersonation", to: "impersonations#destroy", as: :impersonation
    resources :posts
  end

  mount MissionControl::Jobs::Engine, at: "/system/jobs"

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end
