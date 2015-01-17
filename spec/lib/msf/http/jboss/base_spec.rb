#-*- coding:binary -*-
require 'spec_helper'

require 'msf/core'
require 'msf/http/jboss'

describe Msf::HTTP::JBoss::Base do
  subject do
    mod = ::Msf::Exploit.new
    mod.extend Msf::HTTP::JBoss
    mod.send(:initialize)
    mod
  end

  describe "#deploy" do
    before :each do
      allow(subject).to receive(:send_request_cgi) do
        if res_code.nil?
          res = nil
        else
          res = Rex::Proto::Http::Response.new
          res.code = res_code
        end

        res
      end
    end

    let (:opts) do
      {
        'uri' => '/jmx-console'
      }
    end

    it 'returns nil unless uri is provided' do
      expect(subject.deploy).to be_nil
    end

    context 'when server timeouts' do
      let(:res_code) { nil }
      it { expect(subject.deploy(opts, 1)).to be_nil }
    end

    context 'when server returns 200' do
      let(:res_code) { 200 }
      it { expect(subject.deploy(opts)).to be_kind_of Rex::Proto::Http::Response }
    end

    context 'when server returns 404' do
      let(:res_code) { 404 }
      it { expect(subject.deploy(opts, 1)).to be_kind_of Rex::Proto::Http::Response }
    end
  end

  describe "#http_verb" do
    it "returns POST by default" do
      expect(subject.http_verb).to eq("POST")
    end
  end

  describe "#query_serverinfo" do
    before :each do
      allow(subject).to receive(:send_request_cgi) do
        if res_code.nil?
          res = nil
        else
          res = Rex::Proto::Http::Response.new
          res.code = res_code
        end

        res
      end
    end

    context 'when server timeouts' do
      let(:res_code) { nil }
      it { expect(subject.query_serverinfo()).to be_nil }
    end

    context 'when server returns 200' do
      let(:res_code) { 200 }
      it { expect(subject.query_serverinfo()).to be_kind_of Rex::Proto::Http::Response }
    end
  end

  describe "#detect_plateform" do
    context "when server arch is Linux" do
      res = Rex::Proto::Http::Response.new
      res.body = "<td>OSName: Linux</td>"
      it { expect(subject.detect_platform(res)).to eq "linux" }
    end

    context "when server arch is Windows" do
      res = Rex::Proto::Http::Response.new
      res.body = "<td>OSName: Windows</td>"
      it { expect(subject.detect_platform(res)).to eq "win" }
    end

    context "return nil if no OS match" do
      res = Rex::Proto::Http::Response.new
      res.body = "<td>OSName: Blah</td>"
      it { expect(subject.detect_platform(res)).to be_nil }
    end

    context "return nil res is nil" do
      res = nil
      it { expect(subject.detect_platform(res)).to be_nil }
    end
  end

  describe "#detect_architecture" do
    context "when server arch is x86" do
      res = Rex::Proto::Http::Response.new
      res.body = "<td>OSArch: i386</td>"
      it { expect(subject.detect_architecture(res)).to eq ARCH_X86 }
    end

    context "return nil if no architecture match" do
      res = Rex::Proto::Http::Response.new
      res.body = "<td>OSArch: Blah</td>"
      it { expect(subject.detect_architecture(res)).to be_nil }
    end

    context "return nil res is nil" do
      res = nil
      it { expect(subject.detect_architecture(res)).to be_nil }
    end
  end
end