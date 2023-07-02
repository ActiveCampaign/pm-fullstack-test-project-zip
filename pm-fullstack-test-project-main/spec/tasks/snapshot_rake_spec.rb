require 'rails_helper'
require 'rake'

RSpec.describe 'snapshot rake tasks' do
  let(:run_rake_task) do
    Rake::Task['snapshot:take'].reenable
    Rake.application.invoke_task('snapshot:take')
  end

  describe 'snapshot:take' do
    let(:snapshot) { instance_double(Snapshot, persisted?: true) }

    before do
      Rake.application.rake_require 'tasks/snapshot'
      Rake::Task.define_task(:environment)
    end

    context 'when snapshot is nil' do
      it 'outputs error message' do
        allow(Snapshot).to receive(:take).and_return(nil)
        expect { run_rake_task }.to output("Something went wrong while taking the snapshot.\n").to_stdout
      end
    end

    context 'when snapshot fails to persist' do
      it 'outputs error message' do
        allow(Snapshot).to receive(:take).and_return(snapshot)
        allow(snapshot).to receive(:persisted?).and_return(false)
        expect { run_rake_task }.to output("Something went wrong while saving the snapshot.\n").to_stdout
      end
    end

    context 'when snapshot is saved successfully' do
      it 'outputs success message' do
        allow(Snapshot).to receive(:take).and_return(snapshot)
        allow(snapshot).to receive(:persisted?).and_return(true)
        expect { run_rake_task }.to output("Snapshot taken and saved successfully!\n").to_stdout
      end
    end
  end
end
