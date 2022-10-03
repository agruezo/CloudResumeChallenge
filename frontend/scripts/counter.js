window.addEventListener('DOMContentLoaded', (e) => {
    getVisitorCount();
})


const getAPI = "https://api.gruezo.com/counter";
const getVisitorCount = () => {
    let count = 0;

    fetch(getAPI, {method: "POST"})
        .then(response => {
            console.log(response.json())
            return response.json();
        })
        .then(response => {
            console.log("API has been called")
            console.log(response)
            count = response;
            document.getElementById("counter").innerHTML = count;
        })
        .catch(function(error){
            console.log(error);
        });

    return count;
}
