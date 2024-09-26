class ContractService
  attr_accessor :contract

  def initialize(kuri_name, kuri_address, kuri_abi)
    self.contract = Eth::Contract.from_abi(name: kuri_name, address: kuri_address, abi: kuri_abi)
  end


end