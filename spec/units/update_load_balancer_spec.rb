require_relative '../../main'

describe UpdateLoadBalancer do
  describe '#run!' do
    context 'when given a load balancer that is in the system' do
      it 'returns an string of yay' do
        elb_double = load_balancer_collection(
          ['balancer1', 'balancer2']
        )

        output = UpdateLoadBalancer.new('balancer1', [], elb_double).run!

        expect(output).to be true
      end
    end

    context 'when the load balancer does not exist' do
      it 'returns an error' do
        elb_double = load_balancer_collection([])

        output = UpdateLoadBalancer.new('missingbalancer', [], elb_double).run!

        expect(output).to eq('LB missingbalancer does not exist')
      end

      context "when given servers" do
        it "will add the servers to the load balancer" do
          instance_double = double('instance')
          instances_double = double(register: true)
          load_balancer = double(name: 'my-balancer', instances: instances_double)
          elb_double = double(load_balancers: [load_balancer])

          UpdateLoadBalancer.new('my-balancer', [instance_double], elb_double).run!

          expect(instances_double).to have_received(:register).with([instance_double])
        end
      end
    end
  end

  def load_balancer_collection(load_balancer_names)
    load_balancers = load_balancer_names.map do |load_balancer_name|
      double(name: load_balancer_name, instances: double(register: true))
    end

    double(load_balancers: load_balancers)
  end
end
