# frozen_string_literal: true

require_relative("./../../lib/watson_developer_cloud.rb")
require("json")
require("minitest/autorun")
require("minitest/hooks/test")

# Integration tests for the Visual Recognition V3 Service
class VisualRecognitionV3Test < Minitest::Test
  include Minitest::Hooks
  Minitest::Test.parallelize_me!
  attr_accessor :service, :classifier_id
  def before_all
    @service = WatsonDeveloperCloud::VisualRecognitionV3.new(
      api_key: ENV["VISUAL_RECOGNITION_API_KEY"],
      version: "2018-03-19",
      url: "https://gateway-a.watsonplatform.net/visual-recognition/api"
    )
    @classifier_id = "doxnotxdeletexintegrationxtest_397877192"
    @service.add_default_headers(
      headers: {
        "X-Watson-Learning-Opt-Out" => "1",
        "X-Watson-Test" => "1"
      }
    )
  end

  def test_classify
    image_file = File.open(Dir.getwd + "/resources/dog.jpg")
    dog_results = @service.classify(
      images_file: image_file,
      threshold: "0.1",
      classifier_ids: "default"
    ).body
    refute(dog_results.nil?)
  end

  def test_detect_faces
    output = @service.detect_faces(
      url: "https://www.ibm.com/ibm/ginni/images/ginni_bio_780x981_v4_03162016.jpg"
    ).body
    refute(output.nil?)
  end

  def test_custom_classifier
    skip "Time Consuming"
    cars = File.open(Dir.getwd + "/resources/cars.zip")
    trucks = File.open(Dir.getwd + "/resources/trucks.zip")
    classifier = @service.create_classifier(
      name: "CarsVsTrucks",
      classname_positive_examples: cars,
      negative_examples: trucks
    ).body
    refute(classifier.nil?)

    classifier_id = classifier["classifier_id"]
    output = @service.get_classifier(
      classifier_id: classifier_id
    ).body
    refute(output.nil?)

    output = @service.delete_classifier(
      classifier_id: classifier_id
    )
  end

  def test_core_ml_model
    core_ml_model = @service.get_core_ml_model(
      classifier_id: @classifier_id
    )
    refute(core_ml_model.nil?)
  end
end
