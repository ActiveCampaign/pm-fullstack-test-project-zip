desc 'Take a snapshot of in-app communications using the Postmark Messages API'
namespace :snapshot do
  task take: :environment do
    snapshot = Snapshot.take
    snapshot.save

    puts "This Rake task doesn’t do much right now. It’s only got a few pointers to get you started!"
  end
end
