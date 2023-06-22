import { ethers } from "hardhat";
import { expect } from "chai";
import { CappedSet } from "../typechain-types";

describe("CappedSet", function () {
  let cappedSet: CappedSet;

  beforeEach(async function () {
    const CappedSet = await ethers.getContractFactory("CappedSet");
    cappedSet = await CappedSet.deploy(3); // Initialize contract with numElements = 3
  });

  it("should insert elements, update their values and find the lowest one", async function () {
    const [addr1, addr2, addr3, addr4] = await ethers.getSigners();

    // Insert 3 elements
    await expect(await cappedSet.insert(addr1.address, 10))
      .to.emit(cappedSet, "Inserted")
      .withArgs(addr1.address, 10);

    // Check that the lowest element is addr2 with value 5
    await expect(await cappedSet.insert(addr2.address, 5))
      .to.emit(cappedSet, "Inserted")
      .withArgs(addr2.address, 5);

    await expect(await cappedSet.insert(addr3.address, 8))
      .to.emit(cappedSet, "Inserted")
      .withArgs(addr2.address, 5);

    // Check that the lowest element is addr3 with value 3 after updating addr3
    await expect(await cappedSet.insert(addr3.address, 3))
      .to.emit(cappedSet, "Inserted")
      .withArgs(addr3.address, 3);
    expect(await cappedSet.getValue(addr3.address))
      .to.equal(3);
    
    // Check that the lowest element is addr4 with value 2
    await expect(await cappedSet.insert(addr4.address, 2))
      .to.emit(cappedSet, "Inserted")
      .withArgs(addr4.address, 2);
        
    // Check that the addr3 removed 
    await expect(cappedSet.getValue(addr3.address))
      .to.be.revertedWith("element must exist")

    // Remove element at addr3
    await expect(await cappedSet.remove(addr4.address))
      .to.emit(cappedSet, "Removed")
      .withArgs(addr2.address, 5);

  });
});
