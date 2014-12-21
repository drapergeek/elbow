require 'aws-sdk'

class UpdateLoadBalancer
  def initialize(load_balancer, instance_ids, elb)
    @load_balancer = load_balancer
    @instance_ids = instance_ids
    @elb = elb
  end

  def run!
    if matching_load_balancer
      add_servers_to_load_balancer
    else
      "LB #{load_balancer} does not exist"
    end
  end

  def add_servers_to_load_balancer
    load_balancer_instances = matching_load_balancer.instances
    load_balancer_instances.register(instance_ids)
  end

  protected

  attr_reader :load_balancer, :instance_ids, :elb

  def matching_load_balancer
    @matching_load_balancer ||= elb.load_balancers.find do |balancer|
      balancer.name == load_balancer
    end
  end
end

class InstanceFinder
  def initialize(instance_names, ec2_connection)
    @instance_names = instance_names
    @ec2_connection = ec2_connection
  end

  def instances
    ec2_connection.instances.with_tag('Name', instance_names)
  end

  def instance_ids
    instances.map(&:id)
  end

  protected
  attr_reader :instance_names, :ec2_connection
end

load_balancer = ARGV.shift
servers = ARGV

elb = AWS::ELB.new(
  access_key_id: ENV['AWS_ACCESS_KEY'],
  secret_access_key: ENV['AWS_SECRET_KEY'],
  region: 'us-west-2'
)

ec2 = AWS::EC2.new(
  access_key_id: ENV['AWS_ACCESS_KEY'],
  secret_access_key: ENV['AWS_SECRET_KEY'],
  region: 'us-west-2'
)

instance_ids = InstanceFinder.new(servers, ec2).instance_ids
puts UpdateLoadBalancer.new(load_balancer, instance_ids, elb).run!
