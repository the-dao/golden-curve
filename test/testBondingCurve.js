const BigNumber = require('bignumber.js');
const BondingCurve = artifacts.require("BondingCurve")

describe("BondingCurve", () => {
	let bondingCurve
	let coefficient = 50

	it("should deploy", async() => {
		bondingCurve = await BondingCurve.new()
		assert(bondingCurve, "did not deploy")
	})

	it("should calculate phi^1", async() => {
		let ret = await bondingCurve.phiExp(1)
		console.log(ret.toString())
		assert(ret.toNumber() === 161803, "did not calculate c^1")
	})

	it("should calculate phi^2", async() => {
		let ret = await bondingCurve.phiExp(2)
		console.log(ret.toString())
		assert(ret.toNumber() === 261802, "did not calculate c^2")
	})

	it("should calculate phi^3", async() => {
		let ret = await bondingCurve.phiExp(3)
		console.log(ret.toString())
		assert(ret.toNumber() === 423603, "did not calculate c^3")
	})

	it("should calculate e^1", async() => {
		let ret = await bondingCurve.exp(1)
		console.log(ret.toString())
		assert(ret.toNumber() === 2, "did not calculate e^1")
	})

	it("should calculate e^2", async() => {
		let ret = await bondingCurve.exp(2)
		console.log(ret.toString())
		assert(ret.toNumber() === 7, "did not calculate e^2")
	})

	it("should calculate e^3", async() => {
		let ret = await bondingCurve.exp(3)
		console.log(ret.toString())
		assert(ret.toNumber() === 20, "did not calculate e^3")
	})

	it("should calculate e^10", async() => {
		let ret = await bondingCurve.exp(10)
		console.log(ret.toString())
		assert(ret.toNumber() >= 22026*0.9, "did not calculate e^10")
	})

	it("should return a price for supply = 1", async() => {
		let price = await bondingCurve.calculatePrice(1, coefficient)
		console.log(price.toString())
		assert(price.toNumber() === coefficient, "did not return correct price for supply = 1")
	})

	it("should return a price for supply = 31251", async() => {
		let price = await bondingCurve.calculatePrice(31251, coefficient)
		console.log(price.toString())
		assert(price.toNumber() === 258, "did not return correct price for supply = 31251")
	})

	it("should return a price for supply = 93751", async() => {
		let price = await bondingCurve.calculatePrice(93751, coefficient)
		console.log(price.toString())
		assert(price.toNumber() === 418, "did not return correct price for supply = 93751")
	})

	it("should return a price for supply = 188501", async() => {
		let price = await bondingCurve.calculatePrice(188501, coefficient)
		console.log(price.toString())
		assert(price.toNumber() === 677, "did not return correct price for supply = 188501")
	})

	// it("should return a constant price for supply < 100000", async() => {
	// 	let coefficient = 160
	// 	let tokenAmount = 100
	// 	let price = await bondingCurve.calculatePurchaseReturn(1,tokenAmount )
	// 	assert(price == tokenAmount*coefficient, "did not return constant price for supply < 100000")
	// })
})