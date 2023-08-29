/**
 * Copyright 2018 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

locals {
  cluster_type = "node-pool"
}

data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

provider "google" {
  credentials = file("/home/anudeep/fte/terraform/tf1/keys/nht-terraform-811096bd126b.json")
  project     = var.project_id
  region      = var.region
  zone        = var.zones[0]
}

module "gke" {
  source                            = "terraform-google-modules/kubernetes-engine/google"
  project_id                        = var.project_id
  name                              = "${local.cluster_type}-cluster${var.cluster_name_suffix}"
  region                            = var.region
  zones                             = var.zones
  network                           = var.network
  subnetwork                        = var.subnetwork
  ip_range_pods                     = ""
  ip_range_services                 = ""
  http_load_balancing               = false
  create_service_account            = false
  remove_default_node_pool          = false
  disable_legacy_metadata_endpoints = false
  network_policy                    = false
  horizontal_pod_autoscaling        = true
  filestore_csi_driver              = false

  node_pools = [
    # {
    #   name            = "pool-03"
    #   min_count       = 1
    #   max_count       = 2
    #   service_account = var.compute_engine_service_account
    #   auto_upgrade    = true
    # },
    {
      name               = "pool-01"
      machine_type       = "e2-micro"
      node_locations     = "${var.region}-b,${var.region}-c"
      min_count          = 1
      max_count          = 2
      local_ssd_count    = 0
      disk_size_gb       = 10
      disk_type          = "pd-standard"
      image_type         = "COS_CONTAINERD"
      enable_gcfs        = false
      enable_gvnic       = false
      auto_repair        = true
      auto_upgrade       = true
      service_account    = var.compute_engine_service_account
      preemptible        = false
      initial_node_count = 1
    },
    {
      name               = "pool-02"
      machine_type       = "e2-micro"
      node_locations     = "${var.region}-b,${var.region}-c"
      min_count          = 1
      max_count          = 2
      local_ssd_count    = 0
      disk_size_gb       = 10
      disk_type          = "pd-standard"
      image_type         = "COS_CONTAINERD"
      enable_gcfs        = false
      enable_gvnic       = false
      auto_repair        = true
      auto_upgrade       = true
      service_account    = var.compute_engine_service_account
      preemptible        = false
      initial_node_count = 1
    },
  ]

  node_pools_metadata = {
    all = {}

    pool-01 = {
      node-pool-metadata-custom-value = "my-node-pool-01"
    }
    pool-02 = {
      node-pool-metadata-custom-value = "my-node-pool-02"
    }
  }

  node_pools_labels = {
    all = {
      all-pools-example = true
    }
    pool-01 = {
      pool-01-example = true
    }
    pool-02 = {
      pool-02-example = true
    }
  }

  node_pools_taints = {
    all = [
      {
        key    = "all-pools-example"
        value  = true
        effect = "PREFER_NO_SCHEDULE"
      },
    ]
    pool-02 = [
      {
        key    = "nht"
        value  = true
        effect = "PREFER_NO_SCHEDULE"
      },
    ]
  }

  node_pools_tags = {
    all = [
      "all-node-example",
    ]
    pool-01 = [
      "pool-01-example",
    ]
    pool-02 = [
      "pool-02-example",
    ]
  }

  # node_pools_linux_node_configs_sysctls = {
  #   all = {
  #     "net.core.netdev_max_backlog" = "10000"
  #   }
  #   pool-01 = {
  #     "net.core.rmem_max" = "10000"
  #   }
  #   pool-03 = {
  #     "net.core.netdev_max_backlog" = "20000"
  #   }
  # }
}
