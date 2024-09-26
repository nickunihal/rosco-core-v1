class NodeClientService

  def new_client
    node_url = "https://base-sepolia.infura.io/v3/9b65495e103c4139ba83d9d9e58a1ba8"
  	Eth::Client.create node_url
  end

end