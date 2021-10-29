require './lib/middleware'
require 'rspec'

RSpec.describe Maintenance::Middleware do
  let(:app) { ->(_) { [200, {}, []] } }
  let(:env) { { 'REQUEST_METHOD' => 'POST', 'REQUEST_PATH' => '/p1/123/p2' } }

  describe 'default condition' do
    context 'not maintenance' do
      let(:maintenance) { Maintenance::Middleware.new(app) }

      subject { maintenance.call(env) }

      it 'proceed' do
        expect(app).to receive(:call)
        expect { subject }.not_to raise_error
      end
    end
  end

  describe 'and condition' do
    context 'maintenance' do
      let(:condition) { Maintenance::Condition.and(->(_) { true }, ->(_) { true }) }
      let(:maintenance) { Maintenance::Middleware.new(app, { condition: condition }) }

      subject { maintenance.call(env) }

      it 'not proceed' do
        expect(app).not_to receive(:call)
        expect { subject }.not_to raise_error
      end
    end

    context 'not maintenance' do
      let(:condition) { Maintenance::Condition.and(->(_) { true }, ->(_) { false }) }
      let(:maintenance) { Maintenance::Middleware.new(app, condition: condition) }

      subject { maintenance.call(env) }

      it 'proceed' do
        expect(app).to receive(:call)
        expect { subject }.not_to raise_error
      end
    end
  end

  describe 'or condition' do
    context 'maintenance' do
      let(:condition) { Maintenance::Condition.or(->(_) { true }, ->(_) { false }) }
      let(:maintenance) { Maintenance::Middleware.new(app, condition: condition) }

      subject { maintenance.call(env) }

      it 'not proceed' do
        expect(app).not_to receive(:call)
        expect { subject }.not_to raise_error
      end
    end

    context 'not maintenance' do
      let(:condition) { Maintenance::Condition.or(->(_) { false }, ->(_) { false }) }
      let(:maintenance) { Maintenance::Middleware.new(app, condition: condition) }

      subject { maintenance.call(env) }

      it 'proceed' do
        expect(app).to receive(:call)
        expect { subject }.not_to raise_error
      end
    end
  end

  describe 'include method' do
    context 'maintenance' do
      let(:condition) { Maintenance::Condition.include_method('GET', 'PUT', 'POST') }
      let(:maintenance) { Maintenance::Middleware.new(app, condition: condition) }

      subject { maintenance.call(env) }

      it 'not proceed' do
        expect(app).not_to receive(:call)
        expect { subject }.not_to raise_error
      end
    end

    context 'not maintenance' do
      let(:condition) { Maintenance::Condition.include_method('GET', 'PUT') }
      let(:maintenance) { Maintenance::Middleware.new(app, condition: condition) }

      subject { maintenance.call(env) }

      it 'proceed' do
        expect(app).to receive(:call)
        expect { subject }.not_to raise_error
      end
    end
  end

  describe 'exclude method' do
    context 'maintenance' do
      let(:condition) { Maintenance::Condition.exclude_method('GET', 'PUT') }
      let(:maintenance) { Maintenance::Middleware.new(app, condition: condition) }

      subject { maintenance.call(env) }

      it 'not proceed' do
        expect(app).not_to receive(:call)
        expect { subject }.not_to raise_error
      end
    end

    context 'not maintenance' do
      let(:condition) { Maintenance::Condition.exclude_method('GET', 'PUT', 'POST') }
      let(:maintenance) { Maintenance::Middleware.new(app, condition: condition) }

      subject { maintenance.call(env) }

      it 'proceed' do
        expect(app).to receive(:call)
        expect { subject }.not_to raise_error
      end
    end
  end

  describe 'include path' do
    context 'maintenance' do
      let(:condition) { Maintenance::Condition.include_path('^/p1/\d+/p2$', '^/p3/\d+$') }
      let(:maintenance) { Maintenance::Middleware.new(app, condition: condition) }

      subject { maintenance.call(env) }

      it 'not proceed' do
        expect(app).not_to receive(:call)
        expect { subject }.not_to raise_error
      end
    end

    context 'not maintenance' do
      let(:condition) { Maintenance::Condition.include_path('^/p3/\d+$') }
      let(:maintenance) { Maintenance::Middleware.new(app, condition: condition) }

      subject { maintenance.call(env) }

      it 'proceed' do
        expect(app).to receive(:call)
        expect { subject }.not_to raise_error
      end
    end
  end
end

