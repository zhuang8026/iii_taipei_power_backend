<template>
  <div class="download">
    <w-layout :showFilterBar="false" v-loading.fullscreen.lock="loading">
      <div class="container">
        <download-item
          :name="itemList[0].name"
          :url="itemList[0].url"
          @click.native="getItemList()"
        />

        <download-item
          :name="itemList[1].name"
          :url="itemList[1].url"
          @click.native="openElectricityDialog()"
        />

        <download-item
          :name="itemList[2].name"
          :url="itemList[2].url"
          @click.native="openLoginRecordDialog()"
        />

        <download-item
          :name="itemList[3].name"
          :url="itemList[3].url"
          @click.native="downloadUserInfo()"
        />

        <download-item
          :name="itemList[4].name"
          :url="itemList[4].url"
          @click.native="openShowSuggestDialog()"
        />

        <download-item
          :name="itemList[5].name"
          :url="itemList[5].url"
          @click.native="openShowWarningDialog()"
        />
      </div>

      <electricity-dialog
        v-model="showElectricityDialog"
        :is-interval="isInterval"
        :loading="loading"
        @changeInterval="changeInterval"
        @changeLoading="changeLoading"
      />
      <login-record-dialog
        v-model="showLoginRecordDialog"
        :is-interval="isInterval"
        :loading="loading"
        @changeInterval="changeInterval"
        @changeLoading="changeLoading"
      />
      <suggest-dialog
        v-model="showSuggestDialog"
        :is-interval="isInterval"
        :loading="loading"
        @changeInterval="changeInterval"
        @changeLoading="changeLoading"
      />
      <warning-dialog
        v-model="showWarningDialog"
        :is-interval="isInterval"
        :loading="loading"
        @changeInterval="changeInterval"
        @changeLoading="changeLoading"
      />
    </w-layout>
  </div>
</template>
<script>
import WLayout from '@/components/Layout';
import backendApi from '@/assets/js/api/backendApi.js';
import DownloadItem from '@/components/Pages/Download/downloadItem';
import LoginRecordDialog from '@/components/Pages/Download/loginRecordDialog';
import ElectricityDialog from '@/components/Pages/Download/electricityDialog';
import SuggestDialog from '@/components/Pages/Download/suggestDialog';
import WarningDialog from '@/components/Pages/Download/warningDialog';
import dayjs from 'dayjs';

export default {
  components: {
    WLayout,
    DownloadItem,
    LoginRecordDialog,
    ElectricityDialog,
    SuggestDialog,
    WarningDialog,
  },
  data() {
    return {
      itemList: [
        {
          name: '用戶設備清單',
          url: 'img-equip-list.png',
        },
        {
          name: '區間用電統計',
          url: 'img-e-consumption.png',
        },
        {
          name: '登入記錄統計',
          url: 'img-login-statistics.png',
        },
        {
          name: '用戶資料下載',
          url: 'icon-user-download.svg',
        },
        {
          name: '節能建議回饋統計',
          url: 'icon-suggest-statistics.svg',
        },
        {
          name: '異常警示統計',
          url: 'icon-warning-statistics.svg',
        },
      ],
      name: '',
      loading: false,
      showElectricityDialog: false,
      showLoginRecordDialog: false,
      showSuggestDialog: false,
      showWarningDialog: false,
      isInterval: false,
    };
  },
  methods: {
    dayjs,
    // 用電設備清單
    async getItemList() {
      const vm = this;
      vm.loading = true;
      const res = await backendApi.getItemList();
      if (res) {
        vm.loading = true;
        const a = document.createElement('a');
        const blob = new Blob([res], { type: 'application/excel' });
        a.href = window.URL.createObjectURL(blob);
        a.download = `${vm.name}用戶設備清單.xlsx`;
        a.style.display = 'none';
        document.body.appendChild(a);
        a.click();
      }
      vm.loading = false;
    },
    // 用戶資料下載
    async downloadUserInfo() {
      const vm = this;
      vm.loading = true;
      const res = await backendApi.downloadUserInfo();
      if (res) {
        vm.loading = true;
        const a = document.createElement('a');
        const blob = new Blob([res], { type: 'application/excel' });
        a.href = window.URL.createObjectURL(blob);
        a.download = `${vm.name}用戶資料清單.xlsx`;
        a.style.display = 'none';
        document.body.appendChild(a);
        a.click();
      }
      vm.loading = false;
    },
    openElectricityDialog() {
      const vm = this;
      vm.showElectricityDialog = true;
      vm.changeInterval(false);
    },
    openLoginRecordDialog() {
      const vm = this;
      vm.showLoginRecordDialog = true;
      vm.changeInterval(false);
    },
    openShowSuggestDialog() {
      const vm = this;
      vm.showSuggestDialog = true;
      vm.changeInterval(false);
    },
    openShowWarningDialog() {
      const vm = this;
      vm.showWarningDialog = true;
      vm.changeInterval(false);
    },
    changeInterval(val) {
      const vm = this;
      vm.isInterval = val;
    },
    changeLoading(val) {
      const vm = this;
      vm.loading = val;
    },
  },
};
</script>
<style lang="scss" scoped>
.container {
  display: grid;
  grid-gap: 2rem 4rem;
  grid-template-rows: repeat(2, 15rem);
  grid-template-columns: repeat(3, 17rem);
  justify-content: center;
  padding: 10rem 0;
}

/deep/ .download-dialog {
  /** 單月、區間切換按鈕 */
  .btn-list {
    display: flex;
    width: 20rem;
    margin: auto;

    .el-button {
      position: unset;
      width: 100%;
      border: 2px solid #ffba31;
      border-radius: unset;
      color: #ffba31;
      background-color: #fff;

      &:active {
        border-color: #ffba31;
        color: #ffba31;
        background-color: #ffba31;
      }
    }

    .el-button + .el-button {
      margin-left: 0;
    }

    .is-active {
      color: #fff;
      background-color: #ffba31;
    }
  }

  .list {
    margin-top: 2rem;

    .block {
      display: flex;
      flex-direction: column;
      width: 20rem;
      margin: auto;

      span {
        margin-bottom: 1rem;
        color: #333;
        font-weight: bolder;
        font-size: 1.25rem;
        font-family: Noto Sans CJK TC, sans-serif;
      }

      /deep/.el-form-item {
        margin-top: 1rem;
      }

      /deep/ .el-date-editor.el-input {
        width: 100%;
        border-color: #b5b5b5;
      }

      /deep/ .el-input__inner {
        padding-left: 2.675rem;
        border-color: #b5b5b5;
        color: #949494;
        font-size: 1.125rem;
        letter-spacing: 0.1rem;
        cursor: pointer;
      }

      /deep/ .el-input__icon {
        width: 1.0625rem;
        background-image: url('~@/assets/img/pages/download/icon-calendar.svg');
        background-repeat: no-repeat;
        background-size: contain;
      }

      /deep/ .el-icon-date::before {
        content: '';
      }

      /deep/ .el-input__prefix {
        top: 0.9rem;
        left: 0.9125rem;
      }

      /deep/ .el-icon-circle-close {
        display: none;
      }
    }

    .range-month {
      /deep/.el-form-item__content {
        margin-bottom: 1rem;
      }

      .text {
        margin-top: 1rem;
        margin-left: 9.5rem;
        text-align: center;
      }
    }
  }
}
</style>
<style lang="scss">
.el-month-table td.today .cell,
.el-date-picker__header-label.active,
.el-date-picker__header-label:hover,
.el-picker-panel__icon-btn:hover,
.el-month-table td.current:not(.disabled) .cell,
.el-month-table td .cell:hover {
  color: #ffba31;
}

.el-picker-panel {
  border-color: #b5b5b5;
}

.el-popper[x-placement^='bottom'] .popper__arrow::after,
.el-popper[x-placement^='bottom'] .popper__arrow {
  display: none;
}

.el-date-picker__header-label {
  color: #949494;
  font-size: 1.125rem;
  font-family: Noto Sans CJK TC, sans-serif;
  letter-spacing: 0.15rem;
}

.el-date-picker__header--bordered {
  margin-bottom: 0;
  padding-bottom: 0.55rem;
  border-bottom: solid 0.0625rem #b5b5b5;
}

.el-date-picker__header {
  margin: 0.55rem 0.75rem;
}

.el-month-table td {
  padding: 0;
}

.el-month-table td .cell {
  font-size: 0.875rem;
}
</style>
