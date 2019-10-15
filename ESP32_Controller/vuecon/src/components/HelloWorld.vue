<template>
  <div class="hello">
    <div class="about">
      <h1>MAX10 Audio Mixer</h1>
      <div class="container">
        <div class="row" v-for="(item, index) in chdata" v-bind:key="index">
          <div class="col-4"></div>
          <span class="align-middle">ch{{index}}</span>
          <div clas="col-7">
            <div class="form-group">
              <input
                type="range"
                class="form-control-range"
                id="formControlRange"
                v-model="chdata[index]"
                min="0"
                max="255"
                @change="setVol(index,chdata[index])"
              />
            </div>
          </div>
          <div clas="col-1">
            <p>{{item}}</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: "HelloWorld",
  data() {
    return {
      chdata: [0, 0],
      ready: false
    };
  },
  created: function() {
    let i;
    this.chdata.splice(32);
    for (i = 0; i < 32; i++) {
      this.$set(this.chdata, i, 0);
    }
    var self = this;
    this.getVol(function(result) {
      for (var key in result) {
        if (key.indexOf("ch") === 0) {
          const ch = key.replace(/[^0-9]/g, "");
          const vol = parseInt(result[key]);
          self.$set(self.chdata, ch, vol);
        }
        self.$data.ready = true;
      }
    });
  },
  methods: {
    getVol: function(callback) {
      var xmlHttpRequest = new XMLHttpRequest();
      xmlHttpRequest.onreadystatechange = function() {
        if (this.readyState == 4 && this.status == 200) {
          if (this.response) {
            callback(this.response);
          }
        }
      };

      xmlHttpRequest.open("GET", "/getvol", true);
      xmlHttpRequest.responseType = "json";
      xmlHttpRequest.send(null);
    },
    setVol: function(ch, vol, callback) {
      var xmlHttpRequest = new XMLHttpRequest();
      xmlHttpRequest.onreadystatechange = function() {
        if (this.readyState == 4 && this.status == 200) {
        }
      };

      xmlHttpRequest.open("GET", "/setvol?ch=" + ch + "&vol=" + vol, true);
      xmlHttpRequest.responseType = "json";
      xmlHttpRequest.send(null);
    }
  }
};
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
h3 {
  margin: 40px 0 0;
}
ul {
  list-style-type: none;
  padding: 0;
}
li {
  display: inline-block;
  margin: 0 10px;
}
a {
  color: #42b983;
}
</style>
