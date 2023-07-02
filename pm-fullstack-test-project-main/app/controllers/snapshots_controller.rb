class SnapshotsController < ApplicationController
  def show
    @snapshot = Snapshot.last
  end
end
