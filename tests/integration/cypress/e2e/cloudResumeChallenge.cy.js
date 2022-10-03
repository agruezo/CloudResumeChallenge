describe("End to End Test", () => {
    it("Testing API", () => {
        cy.request(
            "POST",
            "https://api.gruezo.com/counter"
        ).then((response) => {
            expect(response.body).to.be.a("number");
            const getCount = response.body;
            cy.request(
                "POST",
                "https://api.gruezo.com/counter"
            ).then((response) => {
                expect(response.body).to.be.a("number");
                const putCount = response.body;
                expect(putCount).to.be.greaterThan(getCount);
            });
        });
    });
});
