desc 'Take a snapshot of in-app communications using the Postmark Messages API'
namespace :snapshot do
  task take: :environment do
    snapshot = Snapshot.take
    if snapshot.nil?
      puts "Something went wrong while taking the snapshot."
    elsif snapshot.save
      puts "Snapshot taken and saved successfully!"
    else
      puts "Something went wrong while saving the snapshot."
    end
  end
end
