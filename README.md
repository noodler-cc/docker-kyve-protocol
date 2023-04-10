
![Logo](https://github.com/kyve-org/assets/raw/main/banners/KYSOR.png)

![MIT License](https://img.shields.io/snyk/vulnerabilities/github/noodler-cc/docker-kyve-protocol)
![AGPL License](https://img.shields.io/badge/license-apache-blue.svg)


# Kysor Docker Image

KYSOR is a program that allows you to run protocol nodes with ease. It eliminates the need to manually install and compile protocol binaries for each pool you want to run on. KYSOR is designed to provide a standardized and easier way to run protocol nodes.


## Getting started

### Prerequisites
- Docker
- KYVE Wallet
- [Storage Provider Wallet](https://docs.kyve.network/validators/protocol_nodes/requirements#storage-provider-requirements) (e.g., storage_priv.json)

### Running
1. Run the Docker container using the following command:

        docker run --name kyve-validator \
        -e NETWORK=<network> \
        -e POOL_ID=<pool_id> \
        -e MNEMONIC=<mnemonic_phrase> \
        -v /path/to/your/kysor:/noodle/.kysor \
        -v /path/to/your/storage_priv.json:/noodle/storage_priv.json \
        -d noodlercc/kyve-protocol-nodes:latest


2. Wait for the Kysor node to initialize. You can check the logs using the following command:
    
        docker logs -f kysor-validator

    Once the node is initialized, you should see the message *"INFO - Public Address: <public-address>"*.

### Environment variables

- **NETWORK:** The KYVE network to connect to (e.g., Mainnet, Kaon, or Korellia).
- **POOL_ID:** The KYVE pool to join.
- **MNEMONIC:** (optional): The mnemonic phrase for the validator account.

### Volumes
-  **/noodle/.kysor:** This volume contains the KYVE node configuration files.
-  **/noodle/storage_priv.json:** This volume contains the *storage_priv.json* file.

## Security

We take security seriously and strive to ensure that this Docker image is as secure as possible. Here are some recommended best practices for further improving the security of your environment:

Keep your system up-to-date with the latest security patches.
Follow best practices for securing your Docker environment, such as using Docker Content Trust, limiting access to Docker resources, and using secure networks.
Regularly scan your Docker images for vulnerabilities using tools such as Trivy, Clair, or Anchore.
This Docker image is built on top of the official Ubuntu and Alpine images, and only includes the necessary dependencies for running the Kysor node. However, to further improve the security of your environment, we recommend that you always use the latest version of this Docker image and keep your system up-to-date with security patches.

We regularly scan this Docker image using Trivy, a vulnerability scanner for containers. The results of the latest scan are available in the  [Security tab](https://github.com/noodler-cc/docker-kyve-protocol/security/code-scanning) of this repository.

If you find any security vulnerabilities in this Docker image or have any security concerns, please report them to us by creating an issue or contacting us directly. We appreciate any feedback that can help us improve the security of this Docker image.
