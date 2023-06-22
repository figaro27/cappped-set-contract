// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract CappedSet {
    struct Element {
        uint256 value;
        bool exists;
    }

    mapping(address => Element) private elements;
    address[] private addresses;
    uint256 private numElements;

    event Inserted(address addr, uint256 val);
    event Removed(address addr, uint256 val);

    constructor(uint256 _numElements) {
        require(_numElements > 0, "numElements must be greater than zero");
        numElements = _numElements;
    }

    function insert(address addr, uint256 value)
        public
        returns (address newLowestAddress, uint256 newLowestValue)
    {
        require(value > 0, "value must be greater than zero");

        if (elements[addr].exists) {
            // update existing element
            Element storage element = elements[addr];
            uint256 oldValue = element.value;
            element.value = value;

            if (value >= oldValue) {
                return (addresses[0], elements[addresses[0]].value);
            }
        } else {
            // add new element
            elements[addr] = Element({
                value: value,
                exists: true
            });
            addresses.push(addr);

            if (addresses.length > numElements) {
                // remove lowest element
                address lowest = addresses[0];
                delete elements[lowest];
                addresses[0] = addresses[addresses.length - 1];
                addresses.pop();
            }
        }

        // find new lowest element
        for (uint256 i = 1; i < addresses.length; i++) {
            if (elements[addresses[i]].value < elements[addresses[0]].value) {
                address temp = addresses[0];
                addresses[0] = addresses[i];
                addresses[i] = temp;
            }
        }

        emit Inserted(addresses[0], elements[addresses[0]].value);

        return (addresses[0], elements[addresses[0]].value);
    }

    function update(address addr, uint256 newVal)
        public
        returns (address newLowestAddress, uint256 newLowestValue)
    {
        require(elements[addr].exists, "element must exist");

        return insert(addr, newVal);
    }

    function remove(address addr)
        public
        returns (address newLowestAddress, uint256 newLowestValue)
    {
        require(elements[addr].exists, "element must exist");

        uint256 indexToDelete;
        for (uint256 i = 0; i < addresses.length; i++) {
            if (addresses[i] == addr) {
                indexToDelete = i;
                break;
            }
        }

        for (uint256 i = indexToDelete; i < addresses.length - 1; i++) {
            addresses[i] = addresses[i + 1];
        }
        addresses.pop();
        delete elements[addr];

        // find new lowest element
        for (uint256 i = 1; i < addresses.length; i++) {
            if (elements[addresses[i]].value < elements[addresses[0]].value) {
                address temp = addresses[0];
                addresses[0] = addresses[i];
                addresses[i] = temp;
            }
        }

        emit Removed(addresses[0], elements[addresses[0]].value);

        return (addresses[0], elements[addresses[0]].value);
    }

    function getValue(address addr) public view returns (uint256) {
        require(elements[addr].exists, "element must exist");

        return elements[addr].value;
    }
}