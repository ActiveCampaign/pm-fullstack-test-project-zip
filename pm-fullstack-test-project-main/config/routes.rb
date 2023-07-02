Rails.application.routes.draw do
  root to: 'snapshots#show'

  resource :snapshot, only: %i(show)
end
