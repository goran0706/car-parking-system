// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract CarParkingSystem {
    address private _manager;
    uint256 private _zonesCount;
    uint256 private _ticketsCount;
    mapping(uint256 => Zone) private _zones;
    mapping(uint256 => Ticket) private _tickets;

    enum Payment {
        PENDING,
        COMPLETE
    }

    struct Zone {
        string label;
        uint256 weiPerSecond;
    }

    struct Ticket {
        Zone zone;
        Payment payment;
        string licensePlate;
        uint256 checkIn;
        uint256 checkOut;
    }

    modifier onlyManager() {
        require(msg.sender == _manager);
        _;
    }

    event ParkDetails(string licensePlate, uint256 time);

    constructor(address manager) {
        _manager = manager;
    }

    function setZones(string memory label, uint256 weiPerSecond)
        public
        onlyManager
    {
        Zone memory zone = Zone(label, weiPerSecond);
        _zonesCount++;
        _zones[_zonesCount] = zone;
    }

    function checkIn(uint256 zoneIndex, string memory _licensePlate) public {
        Ticket memory ticket = Ticket({
            zone: _zones[zoneIndex],
            payment: Payment.PENDING,
            licensePlate: _licensePlate,
            checkIn: block.timestamp,
            checkOut: 0
        });

        _ticketsCount++;
        _tickets[_ticketsCount] = ticket;
        emit ParkDetails(ticket.licensePlate, ticket.checkIn);
    }

    function checkOut(uint256 ticketNr) public payable {
        Ticket memory ticket = _tickets[ticketNr];
        require(ticket.payment == Payment.PENDING);

        uint256 timestamp = block.timestamp;
        uint256 time = timestamp - ticket.checkIn;
        uint256 payment = time * ticket.zone.weiPerSecond;
        require(msg.value == payment);

        ticket.checkOut = timestamp;
        ticket.payment = Payment.COMPLETE;
        emit ParkDetails(ticket.licensePlate, ticket.checkOut);
    }

    function getManager() public view onlyManager returns (address) {
        return _manager;
    }

    function setManager(address newManager) public onlyManager {
        _manager = newManager;
    }

    function getZonesCount() public view onlyManager returns (uint256) {
        return _zonesCount;
    }

    function getTicketsCount() public view onlyManager returns (uint256) {
        return _ticketsCount;
    }

    function checkZone(uint256 index)
        public
        view
        onlyManager
        returns (Zone memory)
    {
        return _zones[index];
    }

    function checkTicket(uint256 index)
        public
        view
        onlyManager
        returns (Ticket memory)
    {
        return _tickets[index];
    }
}
