require_relative '../../main'

describe InstanceFinder do
  describe "#instances" do
    it "returns AWS objects for all the instance names given" do
      names = ['blue1', 'blue2']
      aws_double = instances_collection(names)

      instances = InstanceFinder.new(names, aws_double).instances

      expect(instances.first.tags['Name']).to eq('blue1')
      expect(instances.last.tags['Name']).to eq('blue2')
    end
  end


  describe "#instance_ids" do
    it "returns AWS objects for all the instance names given" do
      names = ['blue1', 'blue2']
      aws_double = instances_collection(names)

      instance_ids = InstanceFinder.new(names, aws_double).instance_ids

      expect(instance_ids).to match_array(['blue1','blue2'])
    end
  end

  def instances_collection(instance_names)
    instance_doubles = instance_names.map do |name|
      double(tags: {'Name' => name }, id: name)
    end

    instances  = double(with_tag: instance_doubles)

    double(instances: instances)
  end
end
