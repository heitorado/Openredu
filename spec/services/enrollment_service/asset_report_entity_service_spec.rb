require 'spec_helper'

module EnrollmentService
  describe AssetReportEntityService do
    subject { AssetReportEntityService.new(:lecture => lectures) }
    let(:subj) { Factory(:subject, :space => nil) }
    let(:lectures) do
      3.times.collect { Factory(:lecture, :subject => subj, :owner => subj.owner) }
    end

    before do
      EnrollmentEntityService.new(:subject => subj).
        create(3.times.collect { [Factory(:user), Role[:member]] })
    end

    it "should wrap a collection of lectures" do
      subject.lectures.should == lectures
    end

    context "#create" do
      let(:columns) { [:subject_id, :lecture_id, :enrollment_id] }
      it "should delegate to the importer with correct arguments" do
        values = []
        subj.enrollments.each do |enrollment|
          lectures.each { |l| values << [l.subject_id, l.id, enrollment.id] }
        end

        subject.importer.should_receive(:insert).with(values)
        subject.create
      end

      it "should accept an optional list of Enrollments" do
        values = []
        subj.enrollments.each do |enrollment|
          lectures.each { |l| values << [l.subject_id, l.id, enrollment.id] }
        end

        subject.importer.should_receive(:insert).with(values)
        subject.create(subj.enrollments)
      end

      it "should update grades"
    end
  end
end