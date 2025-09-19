provider "google" {
  #project = var.project_id
  project = "my-resume-472320"
  region  = var.region
}

resource "google_compute_instance" "nginx_vm" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 10
    }
  }

  network_interface {
    network = "default"
    access_config {} # Даём публичный IP
  }

  metadata = {
    # Добавляем SSH-ключ для пользователя ubuntu
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }

  tags = ["http-server", "ansible-target"] # Добавляем тег для Ansible

  # Важно: даём время на инициализацию ОС
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = self.network_interface[0].access_config[0].nat_ip
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
    }
    inline = ["echo 'VM is ready for Ansible'"]
  }
}

resource "google_compute_firewall" "allow_http" {
  name    = "allow-http"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"] # Для безопасности ограничьте свой IP!
  target_tags   = ["ansible-target"]
}

# Output для Ansible
output "vm_public_ip" {
  value = google_compute_instance.nginx_vm.network_interface[0].access_config[0].nat_ip
}

output "vm_ssh_user" {
  value = "ubuntu"
}
