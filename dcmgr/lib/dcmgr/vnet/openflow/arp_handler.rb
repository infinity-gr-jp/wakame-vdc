# -*- coding: utf-8 -*-

module Dcmgr::VNet::OpenFlow

  class ArpHandler
    include Dcmgr::Logger
    include OpenFlowConstants

    attr_reader :network
    attr_reader :entries

    def initialize
      @entries = {}
    end

    def install(nw)
      @network = nw
      network.packet_handlers <<
        PacketHandler.new(Proc.new { |switch,port,message|
                            message.arp? && message.arp_oper == Racket::L3::ARP::ARPOP_REQUEST
                          }, Proc.new { |switch,port,message|
                            self.handle(port, message)
                          })
    end

    def add(mac, ip, owner)
      raise "Duplicate ip in arp handler." if entries.has_key? ip

      if network.virtual
        flow = Flow.new(TABLE_VIRTUAL_DST, 3, {:reg1 => network.id, :arp => nil, :nw_dst => ip.to_s}, {:controller => nil})
      else
        raise "Only virtual networks handled atm."
      end

      network.datapath.add_flows([flow])
      entries[ip] = { :mac => mac, :owner => owner }
    end

    def handle(port, message)
      entry = entries[message.arp_tpa]
      return if entry.nil?

      network.datapath.send_arp(message.in_port, Racket::L3::ARP::ARPOP_REPLY,
                                entry[:mac], message.arp_tpa.to_s,
                                message.macsa.to_s, message.arp_spa.to_s)
    end

  end

end
    