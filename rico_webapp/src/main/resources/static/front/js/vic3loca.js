const pdxTxtWebFrontVic3Loca = Vue.component('pdx-txt-web-front-vic3-loca', {
    data() {
        return {
            pdxloca: "",
            pdxjson: "",
            pdxview: "",
            errorMessage: "",
            errors: {}
        }
    },

    mounted() {
        const clipboard = new Clipboard('.clipboard');

        clipboard.on('success', function (e) {
            console.info('Action:', e.action);
            console.info('Text:', e.text);
            console.info('Trigger:', e.trigger);

            e.clearSelection();
        });
    },
    computed: {},
    methods: {
        errorReset: function () {
            this.errorMessage = null
            this.errors = {}
        },
        setError: function (error) {
            const {
                simpleMessage,
                statusCode,
                exceptionDetails
            } = error.response.data;

            this.errorMessage = statusCode + ":" + simpleMessage;
            this.errors = objectToMap(exceptionDetails);
        },
        convertJson: async function () {
            await grecaptcha.ready(async () => {
                const tkn = await grecaptcha.execute(RE_CAPTCHA_V3_SITE_KEY, {action: 'homepage'});

                try {
                    const res = await axios.post("/front/convertLocaToJson", {
                        loca: this.pdxloca,
                        reCaptchaToken: tkn
                    });
                    this.errorReset()
                    this.pdxjson = res.data.json;
                } catch (error) {
                    this.setError(error)
                }
            });
        },
        convertView: async function () {
            const json = JSON.parse(this.pdxjson);
            this.pdxview = this.internal(json)
        },
        internal: function (list) {
            let result = "";
            for(let i=0;i<list.length;i++){
                const item = list[i]

                if(item["type"] === "variable") {
                    result += `<i>${item["id"]}</i>`
                } else if(item["type"] === "shell") {
                    result += `<b>XXX</b>`
                } else if(item["type"] === "tag"){
                    const le = this.internal(list[i].contents)
                    result += `<span>${le}</span>`
                } else if(typeof item === "string"){
                    result += list[i].replace("\\n","<br>")
                }
            }
            return result;
        }
    },
    template: `
    <div class="contents">
      <div class="alert alert-danger" role="alert" v-if="errorMessage">
        <h2>{{errorMessage}}</h2>
        <ul>
          <li v-for="[key, val] in Array.from(errors)">{{key}} : {{val}}</li>
        </ul>
      </div>
      <h1>Victoria 3 localization tool</h1>
        <h2>Localization Text</h2>
        <div>
          <textarea class="form-control" placeholder="paradox loca 10000文字まで" rows="10" v-model="pdxloca"></textarea>
        </div>
        <div class="input-group" style="width:100%">
            <div class="input-group-prepend">
              <button class="btn btn-primary" type="button" id="button-convert-json" @click="convertJson">↓変換↓</button>
            </div>
        </div>
        <h2>JSON</h2>
        <div>
          <textarea class="form-control" placeholder="paradox json 10000文字まで" rows="10" v-model="pdxjson"></textarea>
        </div>
        <div class="input-group" style="width:100%">
            <div class="input-group-prepend">
              <button class="btn btn-primary" type="button" id="button-convert-view" @click="convertView">↓変換↓</button>
            </div>
        </div>
        <h2>View</h2>
        <div>
            <div class="form-control" v-html="pdxview"></div>
        </div>      
    </div>
  `
});
