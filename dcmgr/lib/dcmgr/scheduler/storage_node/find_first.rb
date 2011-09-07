# -*- coding: utf-8 -*-

module Dcmgr; module Scheduler; module StorageNode
  class FindFirst < StorageNodeScheduler

    protected
    def schedule_node(volume)
      params = volume.request_params

      volume.storage_pool = Models::StoragePool.first
    end
  end
end; end; end
