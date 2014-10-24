class NextClientBuilder

  attr_accessor :client_verticals, :lead

  def initialize(lead, client_verticals)
    @lead = lead
    @client_verticals = client_verticals
    lead.vertical.update_attributes(next_client: build)
  end

  def integration_name
    lead.vertical.next_client || client_verticals.first.try(:integration_name)
  end

  private

  def manage_clients
    return client_verticals if all_clients_without_weight?
    client_verticals.where.not(weight: nil).order('weight ASC')
  end

  def build
    clients = manage_clients
    count = clients.count
    current_client = clients.find_by_integration_name(integration_name)
    index = clients.index(current_client)

    return first_integration(clients) if index.nil? || last_integration?(index, count)
    next_integration_name(clients, index)
  end

  def first_integration(client_verticals)
    client_verticals[0].try(:integration_name)
  end

  def last_integration?(index, count)
    index + 1 == count
  end

  def next_integration_name(verticals, index)
    verticals[index + 1].integration_name
  end

  def all_clients_without_weight?
    client_verticals.map(&:weight).uniq == [nil]
  end

end